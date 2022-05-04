# wrapper for patator so that we can give it multiple URL
import os


class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


class BruteforceManager:
    mires_file = "/opt/patator/mires.txt"
    patator_path = '/opt/patator/patator.py'
    technical_wordlist = '/root/Wordlists/combo_tech.txt'
    protocol_to_patator = {
        'ftp': 'ftp_login',
        'ssh': 'ssh_login',
        'smtp': 'smtp_login',
    }
    protocol_to_default_port = {
        'ftp': '21',
        'ssh': '22',
        'smtp': '25',
    }
    mires = []

    def __init__(self) -> None:
        with open(self.mires_file) as f:
            self.mires = map(lambda x: str.strip(x).split(','), list(f))

    def launch_bruteforcers(self):
        for m in self.mires:
            bruteforcer = Bruteforcer(self, m)
            bruteforcer.launch_bruteforce()


class Bruteforcer:
    target: str
    port: int
    protocol: str
    patator_module: str
    bruteforceManager: BruteforceManager

    def __init__(self, bruteforceManager, splitted_param: dict) -> None:
        protocol = splitted_param[2]
        port = splitted_param[1] if splitted_param[1] else bruteforceManager.protocol_to_default_port[protocol]
        if port is None:
            raise TypeError('No port defined nor in default')
        self.target = splitted_param[0]
        self.port = port
        self.protocol = protocol
        self.patator_module = bruteforceManager.protocol_to_patator[protocol]
        self.bruteforceManager = bruteforceManager

    def launch_bruteforce(self):
        print(bcolors.FAIL,
              f'starting bruteforce for {self.protocol}://{self.target}:{self.port}')
        print(bcolors.OKBLUE)
        os.system(self.bruteforceManager.patator_path +
                  f' {self.patator_module} host={self.target} user=COMBO00 password=COMBO01 0={self.bruteforceManager.technical_wordlist}')


bruteforceManager = BruteforceManager()
bruteforceManager.launch_bruteforcers()
