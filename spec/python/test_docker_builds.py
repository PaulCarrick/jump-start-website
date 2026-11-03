"""Docker build regression checks; run with unittest discovery."""
import re
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


class DockerBuildTests(unittest.TestCase):
    def test_rails_versions_match_repository(self):
        dockerfile = (ROOT / 'Dockerfile-rails').read_text()
        self.assertIn('ARG RUBY_VERSION=' + (ROOT / '.ruby-version').read_text().strip(), dockerfile)
        bundler = (ROOT / 'Gemfile.lock').read_text().split('BUNDLED WITH\n')[1].strip()
        self.assertIn('gem install bundler -v ' + bundler, dockerfile)

    def test_rails_build_inputs(self):
        text = (ROOT / 'Dockerfile-rails').read_text()
        self.assertIn('ARG RAILS_ENV=production', text)
        self.assertIn('ENV RAILS_PASSWORD=${RAILS_PASSWORD}', text)
        self.assertLess(text.index('COPY ./startup/${SSH_PUBLIC_KEY}'), text.index('./scripts/configure_ssh.sh'))
        self.assertIn('package.json package-lock.json ./', text)
        self.assertIn('RUN npm ci', text)
        self.assertEqual(len(re.findall(r'bundle exec (?:rails|rake) assets:precompile', text)), 1)

    def test_assets_compile_without_database_credentials(self):
        text = (ROOT / 'Dockerfile-rails').read_text()
        self.assertIn('ASSETS_PRECOMPILE=1 SECRET_KEY_BASE_DUMMY=1 DB_PASSWORD=build-only bundle exec rails assets:precompile', text)
        model = (ROOT / 'app/models/concerns/bitemporal_record.rb').read_text()
        self.assertIn("ENV['ASSETS_PRECOMPILE'] != '1' && table_exists?", model)

    def test_database_uses_its_own_environment(self):
        text = (ROOT / 'Dockerfile-database').read_text()
        self.assertIn('COPY ./startup/database/.env /etc/environment', text)
        self.assertNotIn('startup/rails/', text)

    def test_builds_do_not_dump_environment(self):
        for name in ('Dockerfile-rails', 'Dockerfile-database'):
            self.assertNotRegex((ROOT / name).read_text(), r'(?m)^RUN env\s*$')

    def test_ssh_configuration_runs_user_and_key_setup(self):
        script = ROOT / 'startup/scripts/configure_ssh.sh'
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            (work / 'scripts').mkdir()
            for name in ('install_ssh', 'create_ssh_for_user', 'set_ssh_key'):
                stub = work / 'scripts' / (name + '.sh')
                stub.write_text('#!/bin/sh\nprintf "%s\\n" "' + name + ' $*" >> calls\n')
                stub.chmod(0o755)
            subprocess.run(['sh', str(script), 'example', 'setup/key'], cwd=work, check=True, capture_output=True)
            self.assertEqual((work / 'calls').read_text().splitlines(), [
                'install_ssh ', 'create_ssh_for_user example', 'set_ssh_key example setup/key'])


if __name__ == '__main__':
    unittest.main()
