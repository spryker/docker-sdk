# Use case:
Project uses External system for obtaining product prices and availabilities on-the-fly in catalog, via the API. For Dev and acceptance-testing purposes we need to provide a Mock that would emulate behaviour for couple of different use cases

## Implementation
The easiest solution to mock an API - is to implement a separate service based on nginx image:

`pim-mock/docker-compose.yml`:

```yaml
version: '3'

services:  
  pim-mock:
    image: nginx
    volumes:
      - ./pim-mock/nginx.conf:/etc/nginx/nginx.conf
    ports:
      - 5556:8080
    networks:
      private:
          aliases:
            - pim-mock.local
      public:
          aliases:
            - pim-mock.local
```

`pim-mock/nginx.conf`:

```yaml
events {}
http {
    server {
        server_name pim-mock.local;
        listen 8080;
        location /products {
            return 200 "{\"response\":\"[....]\"}";
        }
        location /products/without/stock {
            return 200 "{\"response\":\"[....]\"}";
        }
        location /products/for/customer-a {
            return 200 "{\"response\":\"[....]\"}";
        }
        location /unexpected-error {
            return 500 "{\"response\":\"Something went wrong\"}";
        }
        location /unaothrized/access {
            return 403 "{\"response\":\"forbidden!\"}";
        }
    }
}
```

Include your docker-compose.yml into deploy.dev.yml (and other dev/CI deploy.yml files):

```yaml
compose:
  yamls:
    - pim-mock/docker-compose.yml
```

After that, rebuild the application and the pim-mock.local to your hosts.
The mock service can be accessible via http://pim-mock.local:5556 from the host and http://pim-mock.local:8080 from the other docker containers.
