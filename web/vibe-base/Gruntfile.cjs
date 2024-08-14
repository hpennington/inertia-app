module.exports = function(grunt) {
  grunt.initConfig({
    ts: {
      default: {
        tsconfig: true,
        src: ['src/**/*.ts'],
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
      vibe: {
        files: {
          'dist/index.min.js': ['dist/index.js']
        }
      }
    }
  });

  // Load the plugins
  grunt.loadNpmTasks('grunt-ts');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-watch');

  // Default tasks
  grunt.registerTask('default', ['ts', 'uglify']);
};
