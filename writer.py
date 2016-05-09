from collaborator import Collaborator
from selenium import webdriver
import time


class Writer(Collaborator):
    """docstring for Writer"""
    def __init__(self):
        Collaborator.__init__(self)
        self.__driver = webdriver.Chrome(self.chromedriver)
        self.__driver.get(self.url)