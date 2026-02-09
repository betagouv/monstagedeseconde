#!/bin/sh
# Met à jour la version de ruby dans .tool-versions à partir de .ruby-version

RUBY_VERSION=$(cat .ruby-version | tr -d '\n')
if grep -q '^ruby ' .tool-versions; then
  # Remplace la ligne existante
  sed -i "s/^ruby .*/ruby $RUBY_VERSION/" .tool-versions
else
  # Ajoute la ligne si absente
  echo "ruby $RUBY_VERSION" >> .tool-versions
fi
