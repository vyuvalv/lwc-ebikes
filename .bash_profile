alias sfcreate='sfdx force:org:create -v ARHub -d 30 -f config/project-scratch-def.json --setdefaultusername -a '

alias sfpush='sfdx force:source:push -u '
alias sfpull='sfdx force:source:pull -u '
alias sflist='sfdx force:org:list'
alias sfdelete='sfdx force:org:delete -u '
alias sfopen='sfdx force:org:open -u '
alias sfperm='sfdx force:user:permset:assign -n '

alias sfUpsert='sfdx force:data:bulk:upsert -s Event -i Id -f data/Events.csv -u '

alias sfconvertDX='sfdx force:source:convert -d src/'
alias sfconvertSRC='sfdx force:mdapi:convert -r src/ -d force-app/'

alias sfconnect='sfdx force:auth:web:login -a '
alias sfconnectSB='sfdx force:auth:web:login -r https://test.salesforce.com -a '

alias sfdeploy='sfdx force:mdapi:deploy -w 10 -d src/ -u '
alias sfret='sfdx force:mdapi:retrieve -w 10 -r src/ '

alias sflwc='sfdx force:lightning:component:create -d force-app/main/default/lwc --type lwc -n '
alias vfpage='sfdx force:visualforce:page:create -d force-app/main/default/pages -n '
alias sfcomp='sfdx force:lightning:component:create -d force-app/main/default/aura -n '
alias sfapex='sfdx force:apex:class:create -d force-app/main/default/classes -n '


