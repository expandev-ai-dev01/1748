export interface AISuggestion {
  suggestion_id: string;
  suggestion_type:
    | 'RECURRING_TASK'
    | 'TASK_FROM_INTEGRATION'
    | 'TAG_SUGGESTION'
    | 'PROJECT_SUGGESTION';
  source_content?: string;
  suggested_action_payload: Record<string, unknown>;
  status: 'PENDING' | 'ACCEPTED' | 'REJECTED';
  created_at: string;
}

export interface AutomationRule {
  automation_rule_id: string;
  rule_name: string;
  trigger: {
    type: string;
    conditions: Array<{
      field: string;
      operator: string;
      value: unknown;
    }>;
  };
  actions: Array<{
    type: string;
    params: Record<string, unknown>;
  }>;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface DelegationSuggestion {
  user_id: string;
  user_name: string;
  reason: string;
  confidence: number;
}

export interface TaskOptimization {
  subtasks?: Array<{
    title: string;
    description?: string;
  }>;
  estimated_deadline?: string;
  dependencies?: string[];
}

export interface AIFeedback {
  feedback_id: string;
  source_suggestion_id: string;
  was_suggestion_helpful: boolean;
  correction_payload?: Record<string, unknown>;
  created_at: string;
}

export interface CreateAutomationRuleDto {
  rule_name: string;
  trigger: {
    type: string;
    conditions: Array<{
      field: string;
      operator: string;
      value: unknown;
    }>;
  };
  actions: Array<{
    type: string;
    params: Record<string, unknown>;
  }>;
  is_active?: boolean;
}

export interface UpdateAutomationRuleDto {
  rule_name?: string;
  trigger?: {
    type: string;
    conditions: Array<{
      field: string;
      operator: string;
      value: unknown;
    }>;
  };
  actions?: Array<{
    type: string;
    params: Record<string, unknown>;
  }>;
  is_active?: boolean;
}
