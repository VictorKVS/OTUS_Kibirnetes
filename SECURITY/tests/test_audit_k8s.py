import importlib.util
from pathlib import Path
import unittest

MODULE = Path(__file__).resolve().parents[1] / "agent" / "audit_k8s.py"
spec = importlib.util.spec_from_file_location("audit_k8s", MODULE)
audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)

class AuditTests(unittest.TestCase):
    def test_privileged_container_flagged(self):
        obj = {"kind": "Pod", "metadata": {"name": "unsafe"}, "spec": {
            "containers": [{"name": "web", "image": "nginx:1.28",
                            "securityContext": {"privileged": True}}]}}
        rules = {f["rule"] for f in audit.audit_doc(obj, "test.yaml")}
        self.assertIn("K8S-PRIVILEGED", rules)

    def test_empty_manifest(self):
        self.assertEqual(audit.audit_doc(None, "empty.yaml"), [])

if __name__ == "__main__":
    unittest.main()
