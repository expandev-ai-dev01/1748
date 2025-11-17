import type { AISuggestion } from '../../types';

export interface SuggestionCardProps {
  suggestion: AISuggestion;
  onAccept: (suggestionId: string) => void;
  onReject: (suggestionId: string) => void;
  isAccepting: boolean;
  isRejecting: boolean;
  className?: string;
}
