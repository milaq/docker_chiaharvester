![](https://www.chia.net/img/chia_logo.svg)

# Chia harvester docker image
A simple and scalable docker image for harvesting Chia plots.

## Configuration
Required configuration:
* `FARMER_HOST`: Hostname or IP address of the farmer instance
* Bind mounting your plot dir in the container to `/chia/plots`
* Bind mounting the Chia CA dir from your farmer in the container to `/chia/ca/`

Optional configuration:
* `FARMER_PORT`: Port number of the farmer instance (default: `8447`)
* `HARVESTER_LOGLEVEL`: Log level for the harvester, e.g. `INFO` or `WARNING` (default: `WARNING`)
* `PLOTS_REFRESH_FREQUENCY`: How often the harvester should look for added plots in seconds (default: `1800`)

Also have a look at [the Chia CLI documentation](https://github.com/Chia-Network/chia-blockchain/wiki/CLI-Commands-Reference) for more info on what each setting does.

Don't forget to expose the harvester port (`-p 8448:8448`) if you're using this container standalone.

## Example
Running a harvester with the default options:
```
docker run -d --name chiaharvester12 -e FARMER_HOST=farmer3.example.com -v /mnt/chia/plots/:/chia/plots -v /etc/chia/farmer3/ca/:/chia/ca/ -p 8448:8448 chiaharvester
```
