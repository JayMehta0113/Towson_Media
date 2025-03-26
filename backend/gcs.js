const { Storage } = require('@google-cloud/storage');

// Path to your service account key JSON file
const storage = new Storage({ keyFilename: 'servicekey.json' });

const bucketName = 'image_storage_tu_media';
const bucket = storage.bucket(bucketName);

module.exports = { bucket };