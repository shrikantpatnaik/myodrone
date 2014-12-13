module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    coffee:
      glob_to_multiple:
        expand: true,
        flatten: true,
        cwd: 'src/',
        src: ['*.coffee'],
        dest: 'build/',
        ext: '.js'
    uglify:
      options:
        banner: "/*! <%= pkg.name %> <%= grunt.template.today(\"yyyy-mm-dd\") %> */\n"

      build:
        src: "build/<%= pkg.name %>.js"
        dest: "build/<%= pkg.name %>.min.js"

    nodemon:
      dev:
        script: "build/<%= pkg.name %>.min.js"
        watch: ["build/<%= pkg.name %>.min.js"]
    watch:
      files: ['src/*.coffee']
      tasks: ['coffee', 'uglify', ]

    concurrent:
      dev: ['nodemon', 'watch']
      options:
        logConcurrentOutput: true



  # Load the plugin that provides the "uglify" task.
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-nodemon"
  grunt.loadNpmTasks('grunt-concurrent');

  # Default task(s).
  grunt.registerTask "default", ["concurrent:dev"]


  grunt
