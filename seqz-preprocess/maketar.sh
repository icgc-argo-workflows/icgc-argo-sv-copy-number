echo "{
  \"tool\": {
    \"name\": \"samtools\",
    \"version\": \"$(samtools --version 2>&1 | sed 's/Version.//')\"
  },
  \"metrics\": }" > samtools.json

echo "{
  \"tool\": {
    \"name\": \"tabix\",
    \"version\": \"$(tabix --version 2>&1 | sed 's/Version.//')\"
  },
  \"metrics\": }" > tabix.json

echo "{
  \"tool\": {
    \"name\": \"sequenza-utils\",
    \"version\": \"$(sequenza-utils --version 2>&1 | sed 's/Version.//')\"
  },
  \"metrics\": }" > sequenza-utils.json


# make tar_content.json
echo "{
  \"samtools.json\": \"samtools.json\",
  \"tabix.json\": \"tabix.json\",
  \"sequenza-utils.json\": \"sequenza-utils.json\",
  \"sample_bin50.seqz.gz\": \"sample_bin50.seqz.gz\"
}" > tar_content.json

# tar the results
tar -czf seqz-preprocess.tgz samtools.json tabix.json sequenza-utils.json sample_bin50.seqz.gz tar_content.json
