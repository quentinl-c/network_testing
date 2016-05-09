import json
from config import Config


class ConfigReader(object):
    """docstring for ConfigReader"""
    def __init__(self, path):
        self.__path = path
        self.config = Config()

    def readFromFile(self):
        self.__file = open(self.__path, "r")
        content = self.__file.read()

        try:
            decod_json = json.loads(content)
            print(decod_json)
            exp_name = decod_json['exp_name']
            node_nbr = int(decod_json['node_nbr'])
            typing_speed = int(decod_json['typing_speed'])
            duration = int(decod_json['duration'])
            self.config = Config(exp_name=exp_name, node_nbr=node_nbr,
                                 typing_speed=typing_speed, duration=duration)
        except Exception:
            print("JSON file isn't well formed, please check it and try again")
        finally:
            self.__file.close()
