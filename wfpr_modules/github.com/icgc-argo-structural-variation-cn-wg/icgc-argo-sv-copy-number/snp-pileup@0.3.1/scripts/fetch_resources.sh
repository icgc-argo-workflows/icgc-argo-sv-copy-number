mkdir -p $(dirname $0)/../resources

# No "chr" prefix in contig names
# wget -O $(dirname $0)/../resources/dbsnp_151.common.hg38.vcf.gz https://ftp.ncbi.nih.gov/snp/organisms/human_9606/VCF/00-common_all.vcf.gz

# With "chr" prefix in contig names
wget -O $(dirname $0)/../resources/dbsnp_151.common.hg38.vcf.gz "https://campuscloud.unibe.ch/rest/files/public/links/02dc8054785e096c0179d79a20382c09?passKey=-5889296840140272093&shareId=45112"

echo -e "Checking file integrity.\n"
if [ $(md5sum $(dirname $0)/../resources/dbsnp_151.common.hg38.vcf.gz | cut -f1 -d " ") = "e1050e1014c6726127c4d8d4278e2a6a" ]
then
    echo "Checksum OK."
else
    rm -f $(dirname $0)/resources/hg38.gc50Base.wig.gz
    echo "Checksum failed. Try downloading again."
fi
