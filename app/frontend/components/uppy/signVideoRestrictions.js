export const maxFileSizeMb = 250;
export const restrictions = {
  maxFileSize: maxFileSizeMb * 1024 * 1024,
  maxNumberOfFiles: 1,
  minNumberOfFiles: 1,
  allowedFileTypes: ['video/*', 'application/mp4']
};

export default restrictions;
