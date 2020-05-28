SERVER_IDS = ['Campbell', 'Hill', 'Jaquez', 'Singleton', 'Smith']

# server id as key to a tuple of adjacent node servers and port number
SERVER_CONFIG = {}
SERVER_CONFIG['Campbell'] = (['Singleton', 'Smith'], 8003)
SERVER_CONFIG['Hill'] = (['Jaquez', 'Smith'], 8000)
SERVER_CONFIG['Jaquez'] = (['Hill', 'Singleton'], 8001)
SERVER_CONFIG['Singleton'] = (['Campbell', 'Jaquez', 'Smith'], 8004)
SERVER_CONFIG['Smith'] = (['Campbell', 'Hill', 'Singleton'], 8002)


API_KEY = 'AIzaSyANPmtmz89iKnyDvUu4JSDbFpdmZh6oRc4'
REQUEST_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
