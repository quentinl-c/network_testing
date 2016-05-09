import threading


URL = "https://www.google.fr/"
CHROMEDIRVER = "./chromedriver"
result_writer = "default.txt"


class Collaborator(threading.Thread):
    """docstring for Collaborator"""
    def __init__(self, result_writer=result_writer, url=URL,
                 chromedriver=CHROMEDIRVER):
        threading.Thread.__init__(self)
        self.result_writer = result_writer
        self.url = url
        self.chromedriver = chromedriver
