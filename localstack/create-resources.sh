echo "create a EICAR malware file"
echo 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' > /tmp/files/not_malware.txt

echo "create s3 bucket for file upload"
awslocal s3 mb s3://uploads
awslocal s3 cp /tmp/files/R_Project_Handbook.pdf  s3://uploads/R_Project_Handbook.pdf
awslocal s3 cp /tmp/files/not_malware.txt  s3://uploads/not_malware.txt

echo "All resources initialized! 🚀"
