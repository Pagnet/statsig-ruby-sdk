require_relative 'test_helper'
require 'minitest/autorun'
require 'statsig'

class MultiGateConditionTest < BaseTest
  suite :MultiGateConditionTest

  def setup
    super
    json_file = File.read("#{__dir__}/data/download_config_specs_multi_gate.json")
    Statsig.initialize(
      SDK_KEY,
      StatsigOptions.new(
        bootstrap_values: json_file,
        local_mode: true,
        disable_diagnostics_logging: true,
        logging_interval_seconds: 9999,
        disable_evaluation_memoization: true
      )
    )
  end

  def teardown
    super
    Statsig.shutdown
  end

  def test_multi_pass_gate_passes_when_any_gate_passes
    gate = Statsig.get_gate(user('a_user'), 'multi_pass_gate_check', nil)

    assert_equal(true, gate.value)
    assert_equal('multiPassRuleID', gate.rule_id)
  end

  def test_multi_pass_gate_fails_when_no_gate_passes
    gate = Statsig.get_gate(user('3'), 'multi_pass_segment_check', nil)

    assert_equal(false, gate.value)
    assert_equal('default', gate.rule_id)
  end

  def test_multi_pass_gate_on_segments
    assert_equal(true, Statsig.check_gate(user('1'), 'multi_pass_segment_check'))
    assert_equal(true, Statsig.check_gate(user('2'), 'multi_pass_segment_check'))
  end

  def test_multi_fail_gate_passes_when_any_gate_fails
    gate = Statsig.get_gate(user('a_user'), 'multi_fail_gate_check', nil)

    assert_equal(true, gate.value)
    assert_equal('multiFailRuleID', gate.rule_id)
  end

  def test_multi_fail_gate_fails_when_every_gate_passes
    gate = Statsig.get_gate(user('a_user'), 'multi_fail_gate_all_pass_check', nil)

    assert_equal(false, gate.value)
    assert_equal('default', gate.rule_id)
  end

  private

  def user(user_id)
    StatsigUser.new({ 'userID' => user_id })
  end
end
