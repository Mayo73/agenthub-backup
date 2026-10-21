extends "res://tests/base_test.gd"

func test_wartezeit() -> void:
	var policy := RetryPolicy.new()
	check_eq(policy.delay(1), 0.5, "delay(1) sollte 0.5 sein")
	check_eq(policy.delay(3), 2.0, "delay(3) sollte 2.0 sein")
	check_eq(policy.delay(10), 8.0, "delay(10) sollte 8.0 sein (gecapped)")

func test_wiederholen() -> void:
	var policy := RetryPolicy.new()
	check(policy.should_retry(1, "verbindung"), "should_retry(1, \"verbindung\") sollte wahr sein")
	check(not policy.should_retry(3, "verbindung"), "should_retry(3, \"verbindung\") sollte falsch sein (max_attempts erreicht)")

func test_nicht_wiederholbar() -> void:
	var policy := RetryPolicy.new()
	check(not policy.should_retry(1, "ungueltig"), "should_retry(1, \"ungueltig\") sollte falsch sein")

func test_eigene_werte() -> void:
	var policy := RetryPolicy.new(5, 1.0, 3.0)
	check_eq(policy.delay(2), 2.0, "delay(2) mit eigenen Werten sollte 2.0 sein")
	check_eq(policy.delay(4), 3.0, "delay(4) mit eigenen Werten sollte 3.0 sein (gecapped)")
	check(policy.should_retry(4, "ueberlastet"), "should_retry(4, \"ueberlastet\") sollte wahr sein (max_attempts=5)")
