#!/bin/bash

while getopts "d:hp:" opt; do
  case $opt in
    d)
      domains=$OPTARG 
      ;;
    p)
      breached_dir=$OPTARG 
      ;;
    h)
      echo "Parse the data with the given domains"
      echo "Usage : ./breach_parser.sh -d domains -p path"
      echo "  -d Comma separated list of domains to search for. i.e securiview.net,securiview.com"
      echo "  -p Path to the directory containing the breached passwords"
      exit
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ -z ${domains+x} ]; then 
  echo "No domain given."
  echo "Usage : ./breach_parser.sh -d domains -p path"
  exit
elif [ -z ${breached_dir+x} ]; then 
  echo "No path to breach given."
  echo "Usage : ./breach_parser.sh -d domains -p path"
  exit
fi


mkdir -p all_domains
for domain in $(echo $domains | sed 's/,/ /g')
do
  output_breach_dir=$(echo $domain |cut -d "@" -f 1)
  mkdir -p $output_breach_dir
  echo ""
  echo "#################### Starting search for $domain, output in $output_breach_dir/breached #######################"


  LC_ALL=C fgrep -iRh "$domain" $breached_dir | tee $output_breach_dir/breached

  #extracting the data for the domain
  cd $output_breach_dir
  cat breached | grep -v "Binary file" > breached_parsed
  cat breached_parsed | cut -d ":" -f 1 | cut -d "@" -f 1 | tr [:upper:] [:lower:]  > breached_usernames
  cat breached_parsed | rev | cut -d ":" -f 1 | rev > breached_passwords
  cat breached_parsed | cut -d ":" -f 1 | tr [:upper:] [:lower:]  > breached_mails
  rm -f breached_base64_format
  for i in $(cat breached_parsed | sed 's/@.*:/:/g' ) ; do printf $i | base64 >> breached_base64_format ; done
  cat breached_parsed >> ../all_domains/breached_parsed
  cd ..

done

cd all_domains

#extracting data for all domains
cat breached_parsed | cut -d ":" -f 1 | cut -d "@" -f 1 | tr [:upper:] [:lower:]  > breached_usernames
cat breached_parsed | rev | cut -d ":" -f 1 | rev > breached_passwords
cat breached_parsed | cut -d ":" -f 1 | tr [:upper:] [:lower:]  > breached_mails
echo "" > breached_base64_format
for i in $(cat breached_parsed | sed 's/@.*:/:/g' ) ; do printf $i | base64 >> breached_base64_format ; done

cd ..
