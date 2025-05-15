
a="$2"
if [ ! -f blogs.yaml ]; then
  touch blogs.yaml
  echo "blogs: []" > blogs.yaml
fi

if [ "$1" = "-p" ]; 
then
  if [ ! -f "blogs/$a" ]; 
  then
    echo "error"
    exit 1
  fi
echo "categories:
    1: Sports
    2: Cinema
    3: Technology
    4: Travel
    5: Food
    6: Lifestyle
    7: Finance"
  yq -i ".blogs += [{file_name: \"$a\", publish_status: true, cat_order: []}]" blogs.yaml
  l=$(yq '.blogs | length' blogs.yaml)
  while true;
  do
    echo "ENTER CATEGORY"
    read x
    yq -i ".blogs[$l].cat_order += [$x]" blogs.yaml

    echo "ADD ANOTHER?(y/n):"
    read t
    if [ "$t" = "n" ]; 
    then
      break
    fi
  done
  cp "blogs/$a" "public/$a"
elif [ "$1" = "-a" ]; 
then
  if [ ! -f "public/$a" ]; 
  then
    exit 1
  fi

  rm "public/$a"
  
l=$(yq '.blogs | length' blogs.yaml)
  for ((i=0; i<l; i++));
  do
    name=$(yq ".blogs[$i].file_name" blogs.yaml)
    if [ "$name" = "$a" ];
    then
      yq -i ".blogs[$i].publish_status = false" blogs.yaml
    fi
  done

elif [ "$1" = "-d" ];
then
  rm -f "blogs/$a"
  rm -f "public/$a"

 l=$(yq '.blogs | length' blogs.yaml)
  for ((i=0; i<l; i++)); 
  do
    name=$(yq ".blogs[$i].file_name" blogs.yaml)
    if [ "$name" = "$a" ];
    then
      yq -i "del(.blogs[$i])" blogs.yaml
      break
    fi
  done

elif [ "$1" = "-e" ]; 
then
 l=$(yq '.blogs | length' blogs.yaml)
  

  for ((i=0; i<l; i++)); 
  do
    name=$(yq ".blogs[$i].file_name" blogs.yaml)
    if [ "$name" = "$a" ]; 
    then
      l=$i
     
    fi
  done
  yq -i ".blogs[$l].cat_order = []" blogs.yaml

  while true; 
  do
    echo "Enter category number:"
    read x
    yq -i ".blogs[$l].cat_order += [$x]" blogs.yaml

    echo "Add another category? (y/n):"
    read t
    if [ "$t" = "n" ];
    then
      break
    fi
  done


else
  exit 1
fi
