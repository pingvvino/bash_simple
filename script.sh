#!/bin/bash 

echo "configfilename;IP address; Port; ConnectionID"
#output format
#prod1.xml;10.10.10.10;3737;TESTID
#filename.xml;DEFAULT.SocketConnectHost;SESSION.SocketConnectPort;SESSION.SenderCompID

cfg.parser () {
    IFS=$'\n' && ini=( $(<$1) )              # convert to line-array
    ini=( ${ini[*]//;*/} )                   # remove comments
    ini=( ${ini[*]/#[/\}$'\n'cfg.section.} ) # set section prefix
    ini=( ${ini[*]/%]/ \(} )                 # convert text2function (1)
    ini=( ${ini[*]/=/=\( } )                 # convert item to array
    ini=( ${ini[*]/%/ \)} )                  # close array parenthesis
    ini=( ${ini[*]/%\( \)/\(\) \{} )         # convert text2function (2)
    ini=( ${ini[*]/%\} \)/\}} )              # remove extra parenthesis
    ini[0]=''                                # remove first element
    ini[${#ini[*]} + 1]='}'                  # add the last brace
    eval "$(echo "${ini[*]}")"               # eval the result
}

read_cfg () {
    cfg.parser $1
    cfg.section.DEFAULT
    entry="$2;$SocketConnectHost;"
    cfg.section.SESSION
    entry+="$SocketConnectPort;$SenderCompID"
    echo "$entry"
}
#update repository
git checkout prod                           # make sure we have 'prod' branch set
git pull                                    # update repository

for cfg_file in *.cfg
do
    xml_file="${cfg_file/\.cfg/.xml}"
    if [ -f $xml_file ]; then              #dont parse uncomplited configuration
        read_cfg $cfg_file $xml_file
    fi
done
