Knife consistency plugin
==================

This plugin is used to check consistency of versions in chef.

It has 2 modes :

- **latest** : checks the latest version of a cookbook against a given environment

- **local** : checks if your local cookbooks are at the latest version (useful when working in a team)

almost a screenshot :
<pre>
[mordor:~] knife consistency latest production
cookbook "beanstalk" has no version constraint in environment production !
cookbook "mcollective" is not up to date. latest is 0.0.11, production has version 0.0.10
cookbook "resolvconf" has no version constraint in environment production !
</pre>

<pre>
[mordor:~] knife consistency local
cookbook "mcollective" is not up to date. latest is 0.0.11, local version is 0.0.10
cookbook "resolvconf" has no local candidate version
cookbook "activemq" is not up to date. latest is 0.0.2, local version is 0.0.1
</pre>

License : WTFPL</br>
Author : Nicolas Szalay < nico |at| rottenbytes |meh| info >

