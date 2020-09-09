package io.github.matsimmelbourne;

import org.matsim.api.core.v01.network.Network;
import org.matsim.api.core.v01.network.NetworkWriter;
import org.matsim.contrib.osm.networkReader.SupersonicOsmNetworkReader;
import org.matsim.core.utils.geometry.CoordinateTransformation;
import org.matsim.core.utils.geometry.transformations.TransformationFactory;
import org.matsim.core.network.algorithms.NetworkCleaner;

public class RunNetworkReader {
    private static final String inputFile = "./inputs/Melbourne.osm.pbf";
    private static final String outputFile = "./matsim-network_v2.xml.gz";
    private static final CoordinateTransformation coordinateTransformation = TransformationFactory.getCoordinateTransformation(TransformationFactory.WGS84, "EPSG:28355");

    public static void main(String[] args) {

        Network network = new SupersonicOsmNetworkReader.Builder()
                .setCoordinateTransformation(coordinateTransformation)
                .build()
                .read(inputFile);
        new NetworkCleaner().run(network);
        new NetworkWriter(network).write(outputFile);
    }

}
