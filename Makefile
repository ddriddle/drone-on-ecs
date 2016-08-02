
install: template.json params.json
	aws cloudformation create-stack --stack-name drone-ci \
	    --template-body file://template.json \
	    --parameters file://params.json \
	    --capabilities CAPABILITY_IAM \
	    --tags Key=Name,Value=drone,Key=netid,Value=ddriddle

check:
	aws cloudformation validate-template --template-body file://template.json
