<a href="https://www.buymeacoffee.com/ubuntupunk" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>

# Codestral Vim Plugin

This Vim plugin integrates with the Codestral AI API to provide basic code completions and a simple chat interface directly within Vim.

## Features

* **Code Completions:** Get AI-powered code suggestions as you type. Completions are context-aware and consider the current filetype.
* **Chat Interface:** Interact with the Codestral chat API directly from Vim. Ask questions, get code explanations, and more.
* **Debug Mode:** Enable debug messages to troubleshoot issues and understand the plugin's behavior.

## Installation

1. **Using a plugin manager (recommended):**
    * **vim-plug:** Add `Plug 'your-github-username/codestral.vim'` to your `init.vim` or `.vimrc` and run `:PlugInstall`.  Replace `your-github-username` with your actual GitHub username.
    * **pathogen:** Clone this repository into your `bundle` directory.
    * **Vundle:** Add `Plugin 'your-github-username/codestral.vim'` to your `vimrc` and run `:PluginInstall`. Replace `your-github-username` with your actual GitHub username.

2. **Manual Installation:**
    * Clone this repository into your Vim plugins directory (typically `~/.vim/pack/codestral/start/`).

## Configuration

1. **API Key:** Set the `CODESTRAL_API_KEY` environment variable to your Codestral API key.

    ```bash
    export CODESTRAL_API_KEY="your_api_key_here"
    ```

## Usage

* **`:CodestralChat`:** Opens a new buffer for interacting with the Codestral chat API. Enter your message at the prompt.
* **`:CodestralCompletionEnable`:** Enables code completions.
* **`:CodestralCompletionDisable`:** Disables code completions.
* **`:CodestralDebug`:** Toggles debug mode on/off. Debug messages are displayed in Vim's message history (`:messages`).

## Troubleshooting

* Check the Vim message history (`:messages`) for error messages.
* Ensure that your API key is set correctly.
* If you encounter issues with code completions, try disabling and re-enabling the feature.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.
The original repo is [ubuntupunk/codestral.vim](https://github.com/ubuntupunk/codestral.vim)


## License

[MIT License](LICENSE)
