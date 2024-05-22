
import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.fs.Path
import org.apache.parquet.example.data.Group
import org.apache.parquet.hadoop.ParquetFileReader
import org.apache.parquet.hadoop.example.GroupReadSupport
import org.apache.parquet.schema.MessageType
import org.apache.parquet.schema.MessageTypeParser
//import org.apache.parquet.schema.MessageTypeParser.MessageTypeBuilder
import org.apache.parquet.schema.Types
import java.io.BufferedWriter
import java.io.FileWriter


// Paths
def parquetFilePath = '/Users/sanjeev/Downloads/sample.parquet'
def csvFilePath = '/Users/sanjeev/Downloads/output.csv'

    LOG.info("Converting ${parquetFile.name} to ${csvOutputFile.name}")

    parquetFilePath = new Path(parquetFile.toURI())

    def configuration = new Configuration(true)

    def readSupport = new GroupReadSupport()
    def readFooter = ParquetFileReader.readFooter(configuration, parquetFilePath)
    def schema = readFooter.getFileMetaData().getSchema()

    readSupport.init(configuration, null, schema)
    def w = new BufferedWriter(new FileWriter(csvFilePath))
    def reader = new ParquetReader<Group>(parquetFilePath, readSupport)
    try {
        Group g = null
        while ((g = reader.read()) != null) {
            writeGroup(w, g, schema)
        }
        reader.close()
    } finally {
        Utils.closeQuietly(w)
    }





//  groovy -cp .:jars/parquet-avro-1.8.1.jar:jars/commons-csv-1.10.0.jar:jars/avro-1.11.2.jar:jars/parquet-hadoop-bundle-1.8.1.jar:jars/hadoop-core-0.20.2-with-200-826.jar:jars/commons-logging-1.2.jar parquet_to_csv.groovy