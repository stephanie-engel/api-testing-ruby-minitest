# api-testing-ruby-minitest
This repo includes a test suite for the Google Geocode API.

Setups:
1. Make sure you have ruby installed on your machine: https://www.ruby-lang.org/en/downloads/
2. Once installed, install the following gems: webmock, minitest, and json_expressions via the following commands in your terminal:
```gem install webmock```
```gem install minitest```
```gem install json_expressions```
3. After the above gems are installed, add these gems to your ```Gemfile``` (on Mac, this can be accessed from within your home directory):
```gem 'webmock'```
```gem 'minitest'```
```gem 'json_expressions'```
4. Clone this repo
5. Once you have a local copy of the repo, you can run the test suite ```test_google_geocode_api.rb``` through your terminal.
 - Within your terminal, navigate to the specific directory that the test suite is located within. For example, on my machine, I used this command in my terminal: ```cd ~/RubymineProjects/google_geocode_api/minitest/```
6. Lastly, run the test with the following command: ```ruby test_google_geocode_api.rb```
7. When the tests pass, you should see a result like this in your terminal: 
```~/RubymineProjects/google_geocode_api/minitest [master] $ ruby test_google_geocode_api.rb
Run options: --seed 44464

# Running:

.........

Finished in 3.229221s, 2.7870 runs/s, 12.3869 assertions/s.
9 runs, 40 assertions, 0 failures, 0 errors, 0 skips```
