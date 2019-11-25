az iot hub device-identity create -n screwberry-iothub -d screwberry -g screwberry-rg --ee false
az iot hub device-identity show-connection-string -n screwberry-iothub --device-id screwberry