import asyncio
import time
import sys
from config import *

#PORT = 8888


async def test(msg):
    print(msg)


async def tcp_echo_client(message, message_whatsat, loop):
    try:
        reader, writer = await asyncio.open_connection('127.0.0.1', PORT,
                                                       loop=loop)
    except ConnectionRefusedError:
        return
    print('Send: %r' % message)
    writer.write(message.encode())

    # time.sleep(30)
    #print('Send: %r' % message_whatsat)

    # writer.write(message_whatsat.encode())
    # data = await reader.readuntil(b'\n\n')
    print('Close the socket')
    data = await reader.readline()
    print('Received: %r' % data.decode())
    time.sleep(3)
    writer.write("still connected\n".encode())
    time.sleep(10)

if __name__ == '__main__':
    if (len(sys.argv) != 3):
        print('Invalid number of arguments. Usage: python3 client.py [SERVER NAME] [ID]')
        exit(1)
    server_name = sys.argv[1]
    client_id = sys.argv[2]
    PORT = SERVER_CONFIG[server_name][1]
    message_iamat = '    IAMAT {} +34.065445-118.444732  {:.9f}\nasd\n'.format(client_id, time.time())
    message_whatsat = 'WHATSAT {} 4 4\n'.format(client_id)
    # print(message_iamat.strip('\n'))
    loop = asyncio.get_event_loop()
    loop.run_until_complete(tcp_echo_client(message_iamat, message_whatsat, loop))
    loop.close()