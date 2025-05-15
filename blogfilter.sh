#!/bin/bash


mod=$(whoami)

len=$(yq '.authors | length' "users.yaml")

for ((i=0; i<len; i++)); 
do
  author=$(yq ".authors[$i].username" "users.yaml")
  blogs="/home/authors/$author/public"
  blogsy="/home/authors/$author/blogs.yaml"

  

  echo "CHECKING: $author"

  for file in "$blogs"/*; 
  do
    cnt=0

    for word in $(< "/home/mods/$mod/blacklist.txt"); 
    do
      wordcnt=$(grep -i -o "$word" "$file" | wc -l)

      if [ "$wordcnt" -gt 0 ];
       then
        echo "'$word' is repeating $wordcnt times in $(basename "$file")"

        length=${#word}
        stars=""
        for ((k=0; k<length; k++)); 
        do
          stars="${stars}*"
        
        done

        sed -i "s/$word/$stars/Ig" "$file"

        cnt=$((cnt + wordcnt))
      fi
    
    done

    if [ "$cnt" -gt 7 ];
     then
      rm "$file"

      total=$(yq '.blogs | length' "$blogsy")
      for ((j=0; j<total; j++));
      do
        name=$(yq ".blogs[$j].file_name" "$blogsy")
        if [ "$name" = "\"$(basename "$file")\"" ];
         then
          yq -i ".blogs[$j].publish_status = false" "$blogsy"
          yq -i ".blogs[$j].mod_comments = \"found $cnt blacklisted words\"" "$blogsy"

          break
        fi
      
      done
    fi
  
  done

done
