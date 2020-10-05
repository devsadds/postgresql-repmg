#!/bin/bash
START_ARG="${1}"
ipaddr=$(ifconfig eth0 | grep 'inet' | awk '{print $2}')
hostname=$(hostname)
version_postgres=$(psql --version | awk '{print $NF}')
trigger_file="standby.signal"

if [[ -f "${POSTGRESQL_DATA_DIR}/${trigger_file}" ]];then
  echo "File ${POSTGRESQL_DATA_DIR}/${trigger_file} exist.Become standby"
  ls -la ${POSTGRESQL_DATA_DIR}/${trigger_file}
  server_role="standby"
else
  echo "File ${POSTGRESQL_DATA_DIR}/${trigger_file} not exist. Become master"
  ls -la ${POSTGRESQL_DATA_DIR}/${trigger_file} || echo "File ${POSTGRESQL_DATA_DIR}/${trigger_file}  not exist"
  server_role="master"
fi

tags="[\"${server_role}\"]"


func_consul_agent_start(){
  echo "Begin func ${FUNCNAME[0]}" 
  echo "{ \"services\": [ { \"name\": \"${CONSUL_SERVICE_NAME}\", \"id\": \"${hostname}-${server_role}\", \"address\": \"${ipaddr}\", \"port\": 5432, \"Tags\": $tags, \"checks\": [ { \"name\": \"check if postgres port is open\", \"tcp\": \"${ipaddr}:5432\", \"interval\": \"7s\", \"timeout\": \"3s\" } ] } ] }" > /tmp/${CONSUL_SERVICE_NAME}.json
  sleep 1;
  echo "show /tmp/${CONSUL_SERVICE_NAME}.json"
  echo "------------------------------------"
  cat /tmp/${CONSUL_SERVICE_NAME}.json
  echo "------------------------------------"
  sleep 1;
  if [[ $(ps aux | grep "consul.*agent.*join" | grep -ve 'grep') == "" ]];then
      if [[ "${START_ARG}" == "wait" ]];then
        echo "Start sleep 35"
        sleep 35;
      fi
      echo "/bin/consul agent -retry-join ${DISCOVERY_SERVICE_HOST} -client 0.0.0.0 -bind ${ipaddr} -node ${SERVER_NAME}-${hostname} -data-dir /tmp -config-file /tmp/${CONSUL_SERVICE_NAME}.json 2>&1 & disown"
      /bin/consul agent -retry-join ${DISCOVERY_SERVICE_HOST} -client 0.0.0.0 -bind ${ipaddr} -node ${SERVER_NAME}-${hostname} -data-dir /tmp -config-file /tmp/${CONSUL_SERVICE_NAME}.json 2>&1 & disown
      echo "sleep 5" && sleep 5
  else
    echo "consul agent already running. Make sigint and start"
    local pid=$(ps aux | grep "consul.*agent.*join" | grep -ve 'grep' | awk '{print $2}')
    kill -s SIGINT $pid && sleep 7;
    /bin/consul agent -retry-join ${DISCOVERY_SERVICE_HOST} -client 0.0.0.0 -bind ${ipaddr} -node ${SERVER_NAME}-${hostname} -data-dir /tmp -config-file /tmp/${CONSUL_SERVICE_NAME}.json 2>&1 & disown
  fi
  echo "End func ${FUNCNAME[0]}" 
}


func_consul_agent_start