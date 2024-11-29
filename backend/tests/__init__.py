# tests/__init__.py

import pytest
from termcolor import colored

def run_tests():
    """Run all tests and print a colored summary."""
    # Run pytest and capture the exit code
    result = pytest.main(["--tb=short", "-q"])  # Use quiet mode for cleaner output

    # Define color and emoji based on test outcome
    if result == 0:
        message = colored("All tests passed! :)", "green")
    else:
        message = colored("Some tests failed! :(", "red")

    # Print the summary message
    print(message)

# Automatically run tests if this file is executed
if __name__ == "__main__":
    run_tests()
