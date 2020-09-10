# matsim-melbourne-example

An example MATSim model for Melbourne.

By default, this project uses the latest (pre-)release. In order to use a different version, edit `pom.xml`.


### Import into IntelliJ

`File -> New -> Project from Version Control` paste the repository url and hit 'clone'. IntelliJ usually figures out
that the project is a maven project. If not: `Right click on pom.xml -> import as maven project`.

### Java Version

The project uses Java 11. Usually a suitable SDK is packaged within IntelliJ. Otherwise, one must install a
suitable sdk manually, which is available [here](https://openjdk.java.net/).

### Building and Running it locally

You can build an executable jar-file by executing the following command:

```sh
mvn clean package
```

This will download all necessary dependencies (it might take a while the first time it is run) and create a file `matsim-melbourne-example-0.0.1-SNAPSHOT.jar` in the top directory. This jar-file can either be double-clicked to start the MATSim GUI, or executed with Java on the command line:

```sh
java -jar matsim-melbourne-example-0.0.1-SNAPSHOT.jar
```
