Fonctionnalité('login');

Exemple('test login fonctionne',  ({ Je }) => {
  Je.suisSurLaPage('/')
  Je.cliqueSur('Mon espace')
  Je.cliqueSur('Je suis un offreur')
  Je.vois("Mon espace professionnel")
});
/*
Pour utiliser FactoryBot et CodeceptJS ensemble dans un projet Rails :

1. Utilisez FactoryBot pour préparer vos données de test côté Rails. Par exemple, créez des fixtures ou des endpoints API pour générer des utilisateurs ou autres modèles nécessaires.

2. Ajoutez une route ou un contrôleur dédié dans Rails pour déclencher FactoryBot via des requêtes HTTP (ex : POST /test/factories/users).

3. Depuis CodeceptJS, utilisez l'action I.sendPostRequest ou I.sendGetRequest pour appeler ces endpoints et créer les données avant vos scénarios de test.

Exemple dans CodeceptJS :
  await I.sendPostRequest('/test/factories/users', { email: 'test@example.com' });

Cela permet de préparer l'état de la base avant d'exécuter les tests end-to-end.

Attention : sécurisez ces endpoints pour qu'ils ne soient accessibles qu'en environnement de test.

Concernant la purge de la base de données :  
Non, ce n'est pas fait automatiquement. Il est recommandé de nettoyer la base (purge ou rollback) entre chaque test pour garantir l'isolation des scénarios.  
Utilisez des gems comme DatabaseCleaner côté Rails, ou créez un endpoint dédié pour réinitialiser la base avant chaque test.

Réponse à votre question :  
Non, CodeceptJS ne joue pas les tests par ordre alphabétique.  
Par défaut, les scénarios d'un même fichier sont exécutés dans l'ordre où ils apparaissent dans le code.  
Si vous lancez plusieurs fichiers de test, l'ordre dépend de la configuration et du système de fichiers, mais il n'est pas garanti qu'ils soient joués par ordre alphabétique.

Les tests peuvent-ils être parallélisés ?
Oui, CodeceptJS supporte l'exécution parallèle des tests via le plugin "workers".  
Vous pouvez configurer le nombre de workers dans le fichier codecept.conf.js avec l'option "workers".  
Attention : la parallélisation nécessite que votre base de données et votre environnement de test soient isolés pour chaque worker, afin d'éviter les conflits de données.

/*
Pour créer un environnement de test étanche avec PostgreSQL et plusieurs schémas lors de la parallélisation des tests :

1. Créez un script Node.js qui, pour chaque worker, génère un schéma dédié (ex : test_worker_1, test_worker_2, etc.).
2. Modifiez la configuration de la base de données Rails (database.yml) pour utiliser le schéma correspondant à chaque worker, via une variable d'environnement (ex : PG_SCHEMA).
3. Avant chaque test, le worker crée son schéma, applique les migrations, et configure la connexion à ce schéma.
4. Après les tests, le schéma peut être supprimé pour nettoyer l’environnement.

Exemple de script Node.js pour préparer les schémas :
*/

async function createSchema(workerId) {
  const schemaName = `test_worker_${workerId}`;
  const client = new Client({
    connectionString: process.env.TEST_DATABASE_URL,
  });
  await client.connect();
  await client.query(`CREATE SCHEMA IF NOT EXISTS ${schemaName};`);
  await client.end();
  console.log(`Schema ${schemaName} ready.`);
}

// Utilisation : créez les schémas pour chaque worker avant de lancer les tests
const workers = process.env.CODECEPT_WORKERS || 4;
for (let i = 1; i <= workers; i++) {
  createSchema(i);
}

/*
Dans Rails (config/database.yml), ajoutez :
  schema_search_path: <%= ENV['PG_SCHEMA'] || 'public' %>

Dans CodeceptJS, pour chaque worker, définissez PG_SCHEMA=test_worker_X avant de lancer les tests.

Ainsi, chaque worker utilise son propre schéma, ce qui garantit l’isolation des données lors de la parallélisation.
*/

/* se teste avec la commande : (CODECEPT_WORKERS=4 [optionnel]) npx codeceptjs run --steps */
