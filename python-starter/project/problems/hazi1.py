from project.problem import Problem
import argparse


class DFAProblem(Problem):

    def initialize_parser(self, parser: argparse.ArgumentParser):
        """
        Initialize the parser with the necessary arguments
        """
        parser.add_argument('--input', help='input file with DFA definition', required=True)
        parser.add_argument('--output', help='output file for the results', required=True)
        parser.add_argument('--check', help='comma-separated words to check', required=True)

    def is_chosen_problem(self, args):
        """
        Check if this is the chosen problem based on the arguments
        """
        return True

    def run(self, args):
        """
        Run the DFA simulation and check the words
        """
        # Beolvasás a fájlból
        dfa = self.read_dfa(args.input)

        # Megvizsgáljuk a megadott szavakat
        words = args.check.split(',')

        # Ellenőrzés és eredmények írása
        results = []
        for word in words:
            if self.is_accepted(dfa, word):
                results.append('IGEN')
            else:
                results.append('NEM')

        # Eredmények kiírása a kimeneti fájlba
        with open(args.output, 'w') as f:
            f.write('\n'.join(results))

    def read_dfa(self, file_path):
        """
        Reads the DFA from the input file
        """
        with open(file_path, 'r') as f:
            lines = f.readlines()

        # DFA adatok feldolgozása
        states = lines[0].strip().split()  # Állapotok
        alphabet = lines[1].strip().split()  # Ábécé
        start_state = lines[2].strip()  # Kezdőállapot
        accept_states = lines[3].strip().split()  # Végállapotok

        # Átmenetek beolvasása
        transitions = {}
        for line in lines[4:]:
            from_state, symbol, to_state = line.strip().split()
            if from_state not in transitions:
                transitions[from_state] = {}
            transitions[from_state][symbol] = to_state

        # DFA reprezentáció
        dfa = {
            'states': states,
            'alphabet': alphabet,
            'start_state': start_state,
            'accept_states': accept_states,
            'transitions': transitions
        }
        return dfa

    def is_accepted(self, dfa, word):
        """
        Check if the DFA accepts the word
        """
        current_state = dfa['start_state']

        for symbol in word:
            if symbol in dfa['transitions'][current_state]:
                current_state = dfa['transitions'][current_state][symbol]
            else:
                return False  # Nincs érvényes átmenet

        return current_state in dfa['accept_states']

# A következőképp futtathatod a programot:
# python -m project --input input_file1.txt --output output_file1.txt --check a,ab,abc
