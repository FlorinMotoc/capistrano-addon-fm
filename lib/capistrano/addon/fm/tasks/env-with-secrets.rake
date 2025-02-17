namespace "env" do
  # Set default values
  set :default_local_path, './'
  set :default_file_to_encrypt, 'cap-secrets-LOCAL.txt'
  set :default_file_to_decrypt, 'cap-secrets.enc.b64'
  set :default_encryption_key_file, 'cap-secrets-encryption-key-LOCAL.txt'

  # uploads .env to server (.env.tmp copied to .env)
  task "upload" do
    invoke! "env:local:check:files:exist"
    invoke "env:upload_local_env_file"
    invoke! "env:decrypt_remote_env_tmp_file"
    on roles(:app) do
      execute "cd #{shared_path} && cp .env.tmp .env", raise_on_non_zero_exit: false
    end
  end
  # compares server .env with local .env (via .env.tmp)
  task "upload:diff" do
    invoke! "env:local:check:files:exist"
    invoke "env:upload_local_env_file"
    invoke! "env:decrypt_remote_env_tmp_file"
    on roles(:app) do
      execute "cd #{shared_path} && diff .env .env.tmp", raise_on_non_zero_exit: false
    end
  end
  # upload local env to server (.env.tmp) - does not decrypt
  task "upload_local_env_file" do
    on roles(:app) do |host|
      if !File.exists?("#{host.properties.env_file_location}")
        puts "local env file `#{host.properties.env_file_location}` does not exist. skipping .env file upload!"
      else
        upload! "#{host.properties.env_file_location}", "#{shared_path}/.env.tmp"
      end
    end
  end
  # decrypt .env file on server (encrypted .env.tmp to decrypted .env.tmp)
  task "decrypt_remote_env_tmp_file" do
    on roles(:app) do
      encryption_key_file = fetch(:encryption_key_file, fetch(:default_encryption_key_file))
      base64_file = fetch(:file_to_decrypt, fetch(:default_file_to_decrypt))
      encrypted_file = base64_file.gsub('.b64', '')
      decrypted_file_tmp = "cap-secrets-tmp.txt"

      # Read the .env file
      env_file = capture(:cat, "#{shared_path}/.env.tmp")

      # Read the encryption key from the local file
      encryption_key = File.read(encryption_key_file).strip

      # Decode and decrypt cap-secrets.enc.b64 into a temporary file cap-secrets-tmp.txt
      execute "base64 -d #{release_path}/#{base64_file} > #{shared_path}/#{encrypted_file} && openssl enc -aes-256-cbc -d -pbkdf2 -in #{shared_path}/#{encrypted_file} -out #{shared_path}/#{decrypted_file_tmp} -pass pass:#{encryption_key}"

      # Read the secrets from the temporary cap-secrets-tmp.txt file
      secrets = {}
      capture(:cat, "#{shared_path}/#{decrypted_file_tmp}").each_line do |line|
        key, value = line.strip.split('=', 2)
        secrets[key] = value.delete('"')
      end

      # Clean up the temporary files
      execute "rm #{shared_path}/#{encrypted_file} && rm #{shared_path}/#{decrypted_file_tmp}"

      # Replace the placeholders in the .env file with the actual secrets
      decrypted_lines = env_file.each_line.map do |line|
        line.gsub(/CAP_ENCRYPTED_SECRETS\[(.*?)\]/) do
          secrets[$1]
        end
      end

      # Write the modified .env file back to the server
      execute :echo, "'#{decrypted_lines.join}' > #{shared_path}/.env.tmp", verbosity: :DEBUG
    end
  end
  namespace :local do
    desc 'Encrypt a local file'
    task :encrypt_file do
      invoke! "env:local:check:files:exist"
      use_local_path = fetch(:local_path, fetch(:default_local_path))
      Dir.chdir(use_local_path) do
        encryption_key_file = fetch(:encryption_key_file, fetch(:default_encryption_key_file))
        file = fetch(:file_to_encrypt, fetch(:default_file_to_encrypt))
        base64_file = fetch(:file_to_decrypt, fetch(:default_file_to_decrypt))
        encrypted_file = base64_file.gsub('.b64', '')

        key = File.read(encryption_key_file).strip

        # Encrypt the file
        system("openssl enc -aes-256-cbc -pbkdf2 -in #{file} -out #{encrypted_file} -k #{key}")
        # Encode the encrypted file with base64
        system("base64 -i #{encrypted_file} -o #{base64_file}")
        # Remove tmp file
        system("rm #{encrypted_file}")

        puts "File #{use_local_path}/#{file} has been encrypted to #{use_local_path}/#{encrypted_file} and base64-encoded to #{use_local_path}/#{base64_file}"
      end
    end

    desc 'Decrypt a local file'
    task :decrypt_file do
      invoke! "env:local:check:files:exist"
      use_local_path = fetch(:local_path, fetch(:default_local_path))
      Dir.chdir(use_local_path) do
        encryption_key_file = fetch(:encryption_key_file, fetch(:default_encryption_key_file))
        base64_file = fetch(:file_to_decrypt, fetch(:default_file_to_decrypt))
        encrypted_file = base64_file.gsub('.b64', '')
        decrypted_file = fetch(:file_to_encrypt, fetch(:default_file_to_encrypt))

        unless File.exist?(base64_file)
          puts "Nothing to decrypt. Run `env:local:encrypt_file` first - to generate initial files with a random encryption key"
        else
          key = File.read(encryption_key_file).strip

          # Decode the base64 file
          system("base64 -d -i #{base64_file} -o #{encrypted_file}")
          # Decrypt the file
          system("openssl enc -d -aes-256-cbc -pbkdf2 -in #{encrypted_file} -out #{decrypted_file} -k #{key}")
          # Remove tmp file
          system("rm #{encrypted_file}")

          puts "File #{use_local_path}/#{base64_file} has been base64-decoded to tmp file #{use_local_path}/#{encrypted_file} and decrypted to #{use_local_path}/#{decrypted_file}"
        end
      end
    end
    task "secrets" do
      invoke! "env:local:check:files:exist"
      use_local_path = fetch(:local_path, fetch(:default_local_path))
      Dir.chdir(use_local_path) do
        file = fetch(:file_to_encrypt, fetch(:default_file_to_encrypt))
        puts "Contents of file #{use_local_path}/#{file}:\n\n"
        system("cat #{file}")
      end
    end
    task "check:files:exist" do
      use_local_path = fetch(:local_path, fetch(:default_local_path))
      unless Dir.exist?(use_local_path)
        raise "Directory `#{use_local_path}` does not exist. create it first"
      end
      Dir.chdir(use_local_path) do
        encryption_key_file = fetch(:encryption_key_file, fetch(:default_encryption_key_file))
        file = fetch(:file_to_encrypt, fetch(:default_file_to_encrypt))

        # Create encryption key file if it doesn't exist
        unless File.exist?(encryption_key_file)
          key = Array.new(40) { rand(65..90).chr }.join
          File.write(encryption_key_file, key)
          puts "Encryption key file #{encryption_key_file} created with a 40-character random key."
        else
          key = File.read(encryption_key_file).strip
        end

        # Create file to encrypt if it doesn't exist
        unless File.exist?(file)
          File.write(file, "ABC=\"def\"\n")
          puts "File to encrypt #{file} created with default content."
        end
      end
    end
  end
end
