"""Behavior checks for the downloadable-container setup."""
import os
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

class DockerSetupTests(unittest.TestCase):
    def test_setup_creates_private_unique_secrets_and_preserves_settings(self):
        with tempfile.TemporaryDirectory() as directory:
            command = [str(ROOT / 'bin/docker-setup')]
            subprocess.run(command, cwd=directory, check=True, capture_output=True)
            path = Path(directory) / '.env'
            original = path.read_bytes()
            values = dict(line.split('=', 1) for line in original.decode().splitlines())
            self.assertGreaterEqual(len(values['ADMIN_PASSWORD']), 16)
            self.assertNotEqual(values['DB_PASSWORD'], values['SECRET_KEY_BASE'])
            self.assertEqual(path.stat().st_mode & 0o777, 0o600)
            self.assertNotEqual(subprocess.run(command, cwd=directory, capture_output=True).returncode, 0)
            self.assertEqual(path.read_bytes(), original)

    def test_quickstart_configuration_is_separate_from_production(self):
        compose = (ROOT / 'compose.yml').read_text()
        release = (ROOT / '.github/workflows/containers.yml').read_text()
        for component in ('rails', 'database'):
            self.assertIn('dockerfile: Dockerfile-' + component + '.quickstart', compose)
            self.assertTrue((ROOT / ('Dockerfile-' + component + '.quickstart.dockerignore')).is_file())
        self.assertIn('file: Dockerfile-${{ matrix.component }}.quickstart', release)
        production = (ROOT / 'Dockerfile-rails').read_text()
        self.assertIn('/rails/scripts/rails-entrypoint.sh', production)
        self.assertNotIn('docker/quickstart/', production)
        quickstart = (ROOT / 'Dockerfile-rails.quickstart').read_text()
        for configuration in ('database.yml', 'puma.rb', 'seeds.rb'):
            self.assertIn('COPY docker/quickstart/' + configuration, quickstart)

    def test_entrypoint_preserves_command_arguments(self):
        # The image uses /rails as its working directory; emulate it by replacing only cd.
        script = (ROOT / 'bin/docker-entrypoint').read_text().replace('cd /rails', 'cd "' + str(ROOT) + '"')
        result = subprocess.run(['sh', '-c', script, 'entrypoint', 'printf', '%s', 'hello world'], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, 'hello world')

    def test_entrypoint_propagates_failure(self):
        script = (ROOT / 'bin/docker-entrypoint').read_text().replace('cd /rails', 'cd "' + str(ROOT) + '"')
        result = subprocess.run(['sh', '-c', script, 'entrypoint', 'sh', '-c', 'exit 23'])
        self.assertEqual(result.returncode, 23)

if __name__ == '__main__':
    unittest.main()
