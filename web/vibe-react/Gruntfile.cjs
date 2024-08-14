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
    watch: {
      scripts: {
        files: ['src/**/*.ts', 'src/**/*.tsx'],
        tasks: ['ts'],
        options: {
          spawn: false,
        },
      },
    }
  });

  // Load the plugins
  grunt.loadNpmTasks('grunt-ts');
  grunt.loadNpmTasks('grunt-contrib-watch');

  // Default tasks
  grunt.registerTask('default', ['ts']);
};
