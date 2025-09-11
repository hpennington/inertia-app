module.exports = function(grunt) {
  grunt.initConfig({
    ts: {
      default: {
        tsconfig: true,
        src: ['src/**/*.ts', 'src/**/*.tsx'],
        dest: 'dist',
        options: {
          sourceMap: true,
          declaration: true,
          outDir: 'dist',
          module: 'es6'
        },
      }
    },
    uglify: {
      inertia: {
        files: {
          'dist/index.min.js': ['dist/index.js']
        }
      }
    },
    watch: {
      scripts: {
        files: ['src/**/*.ts', 'src/**/*.tsx'], // Watch for changes in these files
        tasks: ['ts', 'uglify'], // Run these tasks when changes are detected
        options: {
          spawn: false,
        },
      },
    }
  });

  // Load the plugins
  grunt.loadNpmTasks('grunt-ts');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-watch');

  // Default tasks
  grunt.registerTask('default', ['ts', 'uglify']);
};
