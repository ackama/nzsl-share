import { BasePlugin } from '@uppy/core';
import { nanoid } from 'nanoid';
import EventManager from '@uppy/utils/lib/EventManager';
import ProgressTimeout from '@uppy/utils/lib/ProgressTimeout';
import {
  RateLimitedQueue,
  internalRateLimitedQueue
} from '@uppy/utils/lib/RateLimitedQueue';
import { DirectUpload } from '@rails/activestorage';

// History of this file:
// Based on https://github.com/brainzllc/uppy-activestorage-upload
// which is forked from https://github.com/Sega-Aero/uppy-activestorage-upload
// which is forked from https://github.com/corknine/uppy-activestorage-upload
// which is forked from https://github.com/excid3/uppy-activestorage-upload
// which is forked from https://github.com/Rudiney/uppy-activestorage-upload
// which is forked from https://github.com/glenbray/uppy-activestorage-upload
// which is forked from https://github.com/Sology/uppy-activestorage-upload
//
// Each of these forks added _something_, and even the original we've had
// to update the imports to ES style.
// Because there is no trustworthy fork to actually trust to fix bugs
// going forward, I prefer just vendoring this to make it easier to see
// what's going on.
class ActiveStorageUpload extends BasePlugin {
  constructor(uppy, opts) {
    super(uppy, opts);
    this.type = 'uploader';
    this.id = this.opts.id || 'ActiveStorage';
    this.title = 'ActiveStorage';

    this.defaultLocale = {
      strings: {
        timedOut: 'Upload stalled for %{seconds} seconds, aborting.'
      }
    };

    // Default options
    const defaultOptions = {
      limit: 5,
      timeout: 30 * 1000,
      directUploadUrl: null
    };

    this.opts = { ...defaultOptions, ...opts };

    this.handleUpload = this.handleUpload.bind(this);

    // Simultaneous upload limiting is shared across all uploads with this plugin.
    if (internalRateLimitedQueue in this.opts) {
      this.requests = this.opts[internalRateLimitedQueue];
    } else {
      this.requests = new RateLimitedQueue(this.opts.limit);
    }

    this.uploaderEvents = Object.create(null);
  }

  upload(file, current, total) {
    const opts = this.opts;

    this.uppy.log(`uploading ${current} of ${total}`);
    return new Promise((resolve, reject) => {
      this.uppy.emit('upload-start', file);

      var directHandlers = {
        directUploadWillStoreFileWithXHR: null,
        directUploadDidProgress: null
      };
      directHandlers.directUploadDidProgress = ev => {
        this.uppy.log(
          `[ActiveStorage] ${id} progress: ${ev.loaded} / ${ev.total}`
        );
        // Begin checking for timeouts when progress starts, instead of loading,
        // to avoid timing out requests on browser concurrency queue
        timer.progress();

        if (ev.lengthComputable) {
          this.uppy.emit('upload-progress', file, {
            uploader: this,
            bytesUploaded: ev.loaded,
            bytesTotal: ev.total
          });
        }
      };
      directHandlers.directUploadWillStoreFileWithXHR = request => {
        request.upload.addEventListener('progress', event =>
          directHandlers.directUploadDidProgress(event)
        );
      };

      const { data, meta } = file;

      if (!data.name && meta.name) {
        data.name = meta.name;
      }

      const upload = new DirectUpload(
        data,
        this.opts.directUploadUrl,
        directHandlers
      );
      this.uploaderEvents[file.id] = new EventManager(this.uppy);

      const timer = new ProgressTimeout(opts.timeout, () => {
        upload.abort();
        queuedRequest.done();
        const error = new Error(
          this.i18n('timedOut', { seconds: Math.ceil(opts.timeout / 1000) })
        );
        this.uppy.emit('upload-error', file, error);
        reject(error);
      });

      const id = nanoid();

      const handleDirectUpload = (error, blob) => {
        this.uppy.log(`[ActiveStorage] ${id} finished`);
        timer.done();
        queuedRequest.done();
        if (this.uploaderEvents[file.id]) {
          this.uploaderEvents[file.id].remove();
          this.uploaderEvents[file.id] = null;
        }

        if (!error) {
          this.uppy.emit('upload-success', file, blob);

          return resolve(file);
        }

        this.uppy.log(`[ActiveStorage] ${id} errored`);
        timer.done();
        queuedRequest.done();
        if (this.uploaderEvents[file.id]) {
          this.uploaderEvents[file.id].remove();
          this.uploaderEvents[file.id] = null;
        }

        this.uppy.emit('upload-error', file, error);
        return reject(error);
      };

      const queuedRequest = this.requests.run(() => {
        this.uppy.emit('upload-start', file);

        upload.create(handleDirectUpload);

        return () => {
          timer.done();
          upload.abort();
        };
      });

      this.onFileRemove(file.id, () => {
        queuedRequest.abort();
        reject(new Error('File removed'));
      });

      this.onCancelAll(file.id, () => {
        queuedRequest.abort();
        reject(new Error('Upload cancelled'));
      });
    });
  }

  uploadFiles(files) {
    const promises = files.map((file, i) => {
      const current = parseInt(i, 10) + 1;
      const total = files.length;

      if (file.error) {
        return Promise.reject(new Error(file.error));
      }
      return this.upload(file, current, total);
    });

    return Promise.allSettled(promises);
  }

  onFileRemove(fileID, cb) {
    this.uploaderEvents[fileID].on('file-removed', file => {
      if (fileID === file.id) {
        cb(file.id);
      }
    });
  }

  onRetry(fileID, cb) {
    this.uploaderEvents[fileID].on('upload-retry', targetFileID => {
      if (fileID === targetFileID) {
        cb();
      }
    });
  }

  onRetryAll(fileID, cb) {
    this.uploaderEvents[fileID].on('retry-all', () => {
      if (!this.uppy.getFile(fileID)) {
        return;
      }
      cb();
    });
  }

  onCancelAll(fileID, cb) {
    this.uploaderEvents[fileID].on('cancel-all', () => {
      if (!this.uppy.getFile(fileID)) {
        return;
      }
      cb();
    });
  }

  handleUpload(fileIDs) {
    if (fileIDs.length === 0) {
      this.uppy.log('[ActiveStorage] No files to upload!');
      return Promise.resolve();
    }

    // No limit configured by the user, and no RateLimitedQueue passed in by a "parent" plugin
    // (basically just AwsS3) using the internal symbol
    if (this.opts.limit === 0 && !this.opts[internalRateLimitedQueue]) {
      this.uppy.log(
        '[ActiveStorage] When uploading multiple files at once, consider setting the `limit` option (to `10` for example), to limit the number of concurrent uploads, which helps prevent memory and network issues: https://uppy.io/docs/xhr-upload/#limit-0',
        'warning'
      );
    }

    this.uppy.log('[ActiveStorage] Uploading...');
    const files = fileIDs.map(fileID => this.uppy.getFile(fileID));

    return this.uploadFiles(files).then(() => null);
  }

  install() {
    this.uppy.addUploader(this.handleUpload);
  }

  uninstall() {
    this.uppy.removeUploader(this.handleUpload);
  }
}

export default ActiveStorageUpload;
