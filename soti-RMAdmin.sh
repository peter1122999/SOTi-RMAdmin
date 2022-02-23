#!/bin/bash
dtadmin="dtadmin"
fvrescue="fvrescue"
#Logfiles Are Stored in /var/log/sotirmadmin.log

function startLogs(){
  echo "Revoke Admin Remote Script Triggered" "("`date`")" >> /var/log/sotirmadmin.log
}
#Check Current User, convert to lowercase
function getcurrentUsr(){
  currusr=$(who | awk '/console/{print $1}')
}

#Check if anyone is logged in.
function checkforUSR(){
  if test -z "$currusr"
    then
      echo "No User Is Logged In" "("`date`")" >> /var/log/sotirmadmin.log
      echo "Trying Alternate Method" "("`date`")" >> /var/log/sotirmadmin.log
      altMethod
      checkforUSR
    else
      :
  fi
}
function altMethod(){
  #Reads a list of all admin accounts, puts them into a list, runs the ID command to see if the account is a domain account vs a local account. Ignores the local accounts and puts the domain account into $currusr
  allusr=$(dscacheutil -q group -a name admin |grep -i users: |sed 's/users: //g')
  read -a curusr <<< "$allusr "
  for currusr in "${curusr[@]}";
  do
    if id "$currusr" |grep -iq "safeway01"; then
      :
  fi
done
}
function goLowercase(){
  echo $currusr |awk '{print tolower($0)}'
}
function varTouch(){
  currusr=$(goLowercase)
}

#Checked if logged into DTadmin or FVRescue
function checkifDtadmin(){
  if [[ "$currusr" == "$dtadmin" ]]
    then
      echo "User is logged in as DTAdmin, Halt!" "("`date`")" >> /var/log/sotirmadmin.log
      exit
    elif [[ "$currusr" == "$fvrescue" ]]
     then
      echo "User is logged in as FVRescue, Halt!" "("`date`")" >> /var/log/sotirmadmin.log
      exit
  else
    :
  fi
}
#Check/Verfy the current user is an admin
function checkifAdmin(){
 if dscl . read /Groups/admin |grep GroupMembership |grep -q $currusr; then
    :
  else
    echo "User is not an admin, Halt!" "("`date`")" >> /var/log/sotirmadmin.log
    exit
  fi
}
#Revoke the users admin rights
function rmadminUsr(){
  sudo dseditgroup -o edit -d $currusr -t user admin
  sleep 5
}
function verfiyRm(){
  if dscl . read /Groups/admin |grep GroupMembership |grep -q $currusr; then
    echo "Unable to remove admin rights, Halt!" "("`date`")" >> /var/log/sotirmadmin.log
    exit
  else
    :
  fi
}
function logResults(){
  echo "Admin rights for" $currusr "were removed" "("`date`")" >> /var/log/sotirmadmin.log
}

getcurrentUsr
checkforUSR
varTouch
checkifDtadmin
checkifAdmin
rmadminUsr
verfiyRm
logResults
