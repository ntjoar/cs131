import asyncio
import aiohttp
from config import *
from parse import *
import logging
import sys
import time
import json


def time_diff(client_time):
    server_time = time.time()
    if server_time - float(client_time) >= 0:
        return "+{:.9f}".format(server_time - float(client_time))
    else:
        return "-{:.9f}".format(float(client_time) - server_time)

def log(logger, msg, entry='INPUT'):
    logger.info("{}: {}".format(entry, msg.rstrip()))

async def request_gmaps(url_request):
    async with aiohttp.ClientSession() as sesh:
        async with sesh.get(url_request) as resp:
            return await resp.json()

class Server:
    def __init__(self, serv_nam, server_config):
        self._name = serv_nam
        self._neighbors = dict.fromkeys(SERVER_CONFIG[serv_nam][0])
        self._logger = logging.getLogger(serv_nam)
        self._hdlr = logging.FileHandler('{}.log'.format(serv_nam))
        self._logger.setLevel(logging.INFO)
        self._logger.addHandler(self._hdlr)
        self._clients = {}

    def most_recent_client(self, pmsg, rsp_msg):
        if not pmsg.id in self._clients or (float(pmsg.time) > self._clients[pmsg.id]["time"]):
            self._clients[pmsg.id] = {"time": float(pmsg.time), "lat": pmsg.lat, "long": pmsg.long, "string": rsp_msg.rstrip()}
            return False
        return True

    async def flood_neighbors(self, msg):
        already_flooded = msg.split()[5:]
        for server in SERVER_CONFIG[self._name][0]:
            if server not in already_flooded:
                flood_msg = "{} {}\n".format(msg.rstrip(), self._name)
                await self.flood_server(server, flood_msg)

    async def flood_server(self, server, msg):
        try:
            reader, writer = await asyncio.open_connection('127.0.0.1', SERVER_CONFIG[server][1],
                                                           loop=loop)
            print("CONNECTED to {}".format(server))
            log(self._logger, "Connected to {}".format(server), entry="INTERNAL")
            log(self._logger, msg, entry="OUTPUT to {}".format(server))
            writer.write(msg.encode())
            writer.close()
            print("DISCONNECTED with {}".format(server))
            log(self._logger, "Disconnected with {}".format(server), entry="INTERNAL")
        except ConnectionRefusedError:
            log(self._logger, "Cannot connect to {}".format(server), entry="INTERNAL")
            print("CANNOT CONNECT TO: {}".format(server))
        return

    async def handle_imat(self, pmsg, msg):
        rsp_msg = "AT {} {} {} {} {}\n".format(self._name, time_diff(float(pmsg.time)),
                                                        pmsg.id, pmsg.loc, pmsg.time)
        log(self._logger, rsp_msg, entry='OUTPUT')
        if not self.most_recent_client(pmsg, rsp_msg):
            await self.flood_neighbors("FLOOD {}".format(rsp_msg))
        return rsp_msg

    async def handle_whatsat(self, pmsg):
        if pmsg.id not in self._clients:
            rsp_msg = "NO ID"
        else:
            request_url = "{}location={},{}&radius={}&key={}".format(REQUEST_URL, self._clients[pmsg.id]["lat"], self._clients[pmsg.id]["long"], 1000 * pmsg.radius, API_KEY)
            response_json = await request_gmaps(request_url)
            response_json['results'] = response_json['results'][:pmsg.num_results]
            response_str = "{}\n".format(json.dumps(response_json, indent=3))
            response_str = [char for char, next_char in zip(response_str[0:-1], response_str[1:]) if not(char == '\n' and next_char == '\n')]
            response_str = "".join(response_str)
            rsp_msg = "{}\n{}\n\n".format(self._clients[pmsg.id]["string"], response_str)
            log(self._logger, rsp_msg, entry="OUTPUT")
        return rsp_msg

    async def handle_client(self, r, w):
        loop.create_task(self.handle_maintained_client(r, w))

    async def handle_maintained_client(self, r, w):
        try:
            dat = await r.readuntil()
        except asyncio.IncompleteReadError:
            print("CLIENT EOF DETECTED. CLOSING...")
            w.close()
            return
        msg = dat.decode()
        response = await self.handle_msg(msg)
        if response != NONE:
            try:
                w.write(response.encode())
                await w.drain()
                await self.handle_maintained_client(r, w)
            except ConnectionResetError:
                print("CLIENT DISCONNECTED DURING WRITE PROCESS. CLOSING...")
                w.close()
        else:
            w.close()

    async def handle_msg(self, msg):
        log(self._logger, msg)
        striped_msg = msg.strip()
        parsed_msg = Parsemsg(striped_msg)
        pmsg_type = parsed_msg.check_command()
        response_msg = "? {}".format(msg)
        if pmsg_type == IAMAT and parsed_msg.check_iamat():
            print("RECIEVED: {}".format(msg.rstrip()))
            response_msg = await self.handle_imat(parsed_msg, msg)
            print("SEND: {}".format(response_msg.rstrip()))
        elif pmsg_type == WHATSAT and parsed_msg.check_whatsat():
            print("RECIEVED {}".format(msg.rstrip()))
            whatsat_msg = await self.handle_whatsat(parsed_msg)
            if whatsat_msg != "NO ID":
                response_msg = whatsat_msg
            else:
                log(self._logger, response_msg, entry="OUTPUT")
            print("SEND: {}".format(response_msg.rstrip()))
        elif pmsg_type == FLOOD:
            print("RECIEVED {}".format(msg.rstrip()))
            self.most_recent_client(parsed_msg, " ".join(msg.split()[1:7]))
            await self.flood_neighbors(msg)
            response_msg = NONE
        else:
            print("RECIEVED: {}".format(msg.rstrip()))
            print("SEND: {}".format(response_msg.rstrip()))
            log(self._logger, response_msg, entry="OUTPUT")
        return response_msg


if __name__ == '__main__':
    if (len(sys.argv) != 2):
        print('Invalid use. Usage: python3 server.py [SERVER NAME]')
        exit(1)

    serv_nam = sys.argv[1]
    if not serv_nam in SERVER_IDS:
        print("Invalid server name. Server names: Hill, Jaquez, Smith, Campbell, Singleton")

    server = Server(serv_nam, SERVER_CONFIG[serv_nam])
    loop = asyncio.get_event_loop()
    coro = asyncio.start_server(server.handle_client, '127.0.0.1', SERVER_CONFIG[serv_nam][1], loop=loop)
    server = loop.run_until_complete(coro)
    print(SERVER_CONFIG[serv_nam][0])
    print('Serving on {}'.format(server.sockets[0].getsockname()))
    try:
        loop.run_forever()
    except KeyboardInterrupt:
        print('Keyboard interrupt, closing server...')
        pass

    server.close()
    loop.run_until_complete(server.wait_closed())
    loop.close()
