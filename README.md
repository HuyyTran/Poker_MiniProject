# Poker Hand Checker

This is a Ruby on Rails application that allows users to check and validate poker hands via a web interface and a JSON-based API.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [API Endpoints](#api-endpoints)
- [Web Interface](#web-interface)
- [Testing](#testing)

## Installation

### Prerequisites

- Ruby (version 2.6.3 or later)
- Rails (version 6.0.0 or later)
- Bundler (version 2.1.4 or later)

### Steps

1. Clone the repository:

   ```sh
   git clone https://github.com/yourusername/poker-hand-checker.git
   cd poker-hand-checker
2. Install the dependencies:

    ```sh
    Copy code
    bundle install
3. Set up the database:

    ```sh
    Copy code
    rails db:create
    rails db:migrate
4. Start the Rails server:

    ```sh
    Copy code
    rails server
The application will be accessible at http://localhost:3000.

## Usage

### Web Interface
- Visit http://localhost:3000/pokers/index to access the web interface.
- Enter a poker hand in the text field and submit the form to check the hand.
### API Endpoints
#### Check Poker Hand
- URL: /pokers/api/v1/cards/check

- Method: POST

- Content-Type: application/json

- Parameters:

    - cards: (string or array of strings) The poker hand(s) to check.
- Example Request:

    ```sh
    curl -X POST http://localhost:3000/pokers/api/v1/cards/check \
    -H "Content-Type: application/json" \
    -d '{"cards": ["H1 S10 D11 C12 C13"]}'
Example Response:


{
    "result": [
        {
            "card": "H1 S10 D11 C12 C13",
            "best": true,
            "hand": "straight"
        }
    ]
}

## Testing
### Run Tests
To run the test suite, execute:

    sh
    bundle exec rspec
Ensure you have the necessary test dependencies installed.
