#!/bin/bash

groupadd -f g_admin
groupadd -f g_user
groupadd -f g_author
groupadd -f g_mod


for admin in $(yq '.admins[].username' users.yaml);
do
  useradd "$admin"
  mkdir -p "/home/admin/$admin"
  chown "$admin:g_admin" "/home/admin/$admin"
  chmod 700 "/home/admin/$admin"
done


for user in $(yq '.users[].username' users.yaml);
do
  useradd "$user"
  mkdir -p "/home/users/$user/all_blogs"
  chown -R "$user:g_user" "/home/users/$user"
  chmod -R 700 "/home/users/$user"
done


for author in $(yq '.authors[].username' users.yaml);
do
  useradd "$author"
  mkdir -p "/home/authors/$author/blogs"
  mkdir -p "/home/authors/$author/public"
  chown -R "$author:g_author" "/home/authors/$author"
  chmod 700 "/home/authors/$author"
  chmod 755 "/home/authors/$author/public"
  
  
  for user in $(yq '.users[].username' users.yaml); 
  do
    ln -sf "/home/authors/$author/public" "/home/users/$user/all_blogs/$author"
  done
done


for mod in $(yq '.mods[].username' users.yaml); 
do
  useradd "$mod"
  mkdir -p "/home/mods/$mod"
  chown "$mod:g_mod" "/home/mods/$mod"
  chmod 700 "/home/mods/$mod"

  for author in $(yq ".mods[] | select(.username == \"$mod\") | .authors[]" users.yaml); 
  do
    setfacl -m u:$mod:rw "/home/authors/$author/public"
  done
done


for admin in $(yq '.admins[].username' users.yaml);
do
  setfacl -R -m u:$admin:rwx /home/users
  setfacl -R -m u:$admin:rwx /home/authors
  setfacl -R -m u:$admin:rwx /home/mods
done
