from config_reader import ConfigReader


class Manager(object):
    """docstring for Manager"""
    def __init__(self):
        self.config_reader = ConfigReader('./test.json')
        self.dummy_collaborators = []

    def start(self):
        self.config_reader.readFromFile()

        if self.config_reader.config.node_nbr < 2:
            self.config_reader.config.node_nbr = 2

        if self.config_reader.config.duration <= 0:
            self.config_reader.config.duration = 1

        if self.config_reader.config.typing_speed <= 0:
            self.config_reader.config.typing_speed = 0

        for x in xrange(self.config_reader.config.node_nbr):
            if x == 0:
                t = 0
                # TODO : writer instanciation
            elif x == 1:
                t = 1
                # TODO : reader instanciation
            else:
                t = 3
                # TODO : Dummy writer instanciation
