# api-tests

This simple code snippet makes Metabases API resquests concurrently, in order to test API service

## Build

```
lein uberjar
```

## Usage
```
Parameters:
  -u, --username USER           Metabase user name
  -p, --password PASS           Metabase password
  -s, --server SERVER           Metabase Server
  -f, --url-requests-file FILE  File with requests URI (i.e., :method :uri)
```

```shell
    $ java -jar api-tests-0.1.0-standalone.jar -u METABASE_USER -p PASSWORD_USER -s https://METABASE_SERVER/ -f /PATH/TO/FILE/WITH/REQUESTS
```
Output Example:

```
07-08 14:56:15 INFO api-tests.core : Initializing Metabase UI tests
07-08 14:56:15 INFO api-tests.core : Usage: 
  -u, --username USER                       Metabase user name
  -p, --password PASS                       Metabase password
  -s, --server SERVER                       Metabase Server
  -f, --file-requests-urls "/path/to/file"  File with requests URI (i.e., :method :uri)
07-08 14:56:15 WARN api-tests.requests : Getting token from user: foo@bar.com at https://foo-bar/api/session
07-08 14:56:16 INFO api-tests.core : Metabase Token: 33333333-33333-3333-3333-33333333
07-08 14:56:16 INFO api-tests.requests : Reading file urls-requests.txt
07-08 14:56:16 INFO api-tests.core : Sending API requests to endpoints
07-08 14:56:27 INFO api-tests.requests : URL ->>  https://foo-bar/api/database?include_tables=true Method ->>  :get  Status ->>  200
07-08 14:56:27 INFO api-tests.requests : URL ->>  https://foo-bar/api/card/15995/query/csv Method ->>  :post  Status ->>  202
07-08 14:56:27 INFO api-tests.requests : URL ->>  https://foo-bar/api/card/16288/query/csv Method ->>  :post  Status ->>  202
07-08 14:56:27 INFO api-tests.requests : URL ->>  https://foo-bar/api/card/22675/query/csv Method ->>  :post  Status ->>  202
07-08 14:56:27 INFO api-tests.requests : URL ->>  https://foo-bar/api/card/4855/query/csv Method ->>  :post  Status ->>  400
```

### ToDos
- [ ] SSO Auth
- [ ] Requests with body data
- [ ] Create Summary Report
- [ ] Validate CLI arguments
