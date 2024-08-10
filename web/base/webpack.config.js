const path = require('path')

module.exports = {
  entry: './src/vibe.tsx',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'vibe.js',
    library: 'vibe',
    libraryTarget: 'umd',
    globalObject: 'this',
  },
  resolve: {
    extensions: ['.ts', '.tsx', '.js', '.jsx'],
  },
  module: {
    rules: [
      {
        test: /\.(ts)x?$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            babelrc: false,
            configFile: false,
            presets: ['@babel/preset-env', 'solid', '@babel/preset-typescript']
          }
        }
      }
    ]
  },
  externals: {
    'solid-js': 'solid-js',
  },
  devtool: 'source-map',
};

