# Default values
def_exp_name = "Tutu"
def_nodes_nbr = 10
def_typing_speed = 10
def_duration = 42


class Config(object):
    """docstring for Config"""
    def __init__(self, exp_name=def_exp_name, node_nbr=def_nodes_nbr,
                 typing_speed=def_typing_speed, duration=def_duration):
        self.exp_name = exp_name
        self.node_nbr = node_nbr
        self.typing_speed = typing_speed
        self.duration = duration
