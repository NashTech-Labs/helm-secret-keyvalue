SECRETS_PATH=tmp/secrets
HELM_CHARTS=helm-secrets
VALUES_FILE=$HELM_CHARTS/values.yaml
EXTENDS=extended-values.yaml

mkdir -p $SECRETS_PATH/keyvalues

echo -e "DB_USER=$DB_USER\nDB_PASS=$DB_PASS\nDB_PORT=$DB_PORT\nDB_HOST=$DB_HOST\nMODE=$MODE\nCOSMOS_DB_ENABLED=$COSMOS_DB_ENABLED\n" >> $SECRETS_PATH/keyvalues/dbcred.conf

ENVS=$(ls $SECRETS_PATH/keyvalues)

if [[ $ENVS != "" ]]; then
  sed -i "s@externalSecretsEnabled:.*\$@externalSecretsEnabled: true@g" $VALUES_FILE
  echo -e "externalSecrets:\n  keyValues:" >> $EXTENDS
  for SECRET_ENV_FILES in $ENVS; do
  NAME=$(echo $SECRET_ENV_FILES|awk -F. '{print $1}')
  sed -i "s@=@\ @1" $SECRETS_PATH/keyvalues/$SECRET_ENV_FILES
  echo -e "  - name: $NAME" >> $EXTENDS
  echo -e "    data:" >> $EXTENDS
  while IFS='' read -r line; do
  if [[ -n $line ]]; then
  KEY=$(echo $line|awk '{print $1}')
  VALUE=$(echo $line|awk '{print $2}')
  echo "      $KEY: $VALUE" >> $EXTENDS
  fi
  done < $SECRETS_PATH/keyvalues/$SECRET_ENV_FILES
  done
  echo >> $VALUES_FILE
  cat $EXTENDS >> $VALUES_FILE
  rm $EXTENDS
else
  sed -i "s@externalSecretsEnabled:.*\$@externalSecretsEnabled: false@g" $VALUES_FILE
fi