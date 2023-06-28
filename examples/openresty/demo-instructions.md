### Start openresty

`rm -f tmp/demo-logs && docker-compose run --service-ports --rm openresty > tmp/demo-logs`

### Send some traffic at it

`for i in {1..6}; do sleep 0.25 && curl localhost:80/demo; done`

## Clean up logs

Regex `.*(worker pid.*)\|.*`, replace with $1
