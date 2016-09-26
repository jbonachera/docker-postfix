import pytest

def test_postfix_master_running(Process):
    assert Process.get(comm='master').user == 'root'
#def test_postfix_qmgr_running(Process):
#    assert Process.get(comm='qmgr').user == 'postfix'
#def test_postfix_tlsmgr_running(Process):
#    assert Process.get(comm='tlsmgr').user == 'postfix'
#def test_postfix_pickup_running(Process):
#    assert Process.get(comm='pickup').user == 'postfix'
#def test_postfix_anvil_running(Process):
#    assert Process.get(comm='anvil').user == 'postfix'
#def test_postfix_postscreen_running(Process):
#    assert Process.get(comm='postscreen').user == 'postfix'
#def test_postfix_smtpd_running(Process):
#    assert Process.get(comm='smtpd').user == 'postfix'
def test_postfix_smtp_listening(Socket):
    assert Socket("tcp://25").is_listening
def test_postfix_submission_listening(Socket):
    assert Socket("tcp://587").is_listening
