# matsim-melbourne-example-project

An example MATSim model for Melbourne.

By default, this project uses the latest (pre-)release. In order to use a different version, edit `pom.xml`.


### Import into IntelliJ

`File -> New -> Project from Version Control` paste the repository url and hit 'clone'. IntelliJ usually figures out
that the project is a maven project. If not: `Right click on pom.xml -> import as maven project`.

### Java Version

The project uses Java 11. Usually a suitable SDK is packaged within IntelliJ or Eclipse. Otherwise, one must install a
suitable sdk manually, which is available [here](https://openjdk.java.net/).

### Building and Running it locally

You can build an executable jar-file by executing the following command:

```sh
mvn clean package
```
This will download all necessary dependencies (it might take a while the first time it is run) and create `target/matsim-melbourne-example-1.0-SNAPSHOT-jar-with-dependencies.jar`.

This jar-file can be executed with Java on the command line using:

```sh
java -jar target/matsim-melbourne-example-1.0-SNAPSHOT-jar-with-dependencies.jar
```
